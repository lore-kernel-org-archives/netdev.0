From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: wireless/atmel: remove time_t usage
Date: Wed, 8 Mar 2017 17:10:25 +0100
Message-ID: <20170308161025.nxz6puyeo3ezwa43@piout.net>
References: <20170223161445.19200-1-alexandre.belloni@free-electrons.com>
 <20170308151340.9D6E360209@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Simon Kelley <simon@thekelleys.org.uk>, linux-wireless@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170308151340.9D6E360209@smtp.codeaurora.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

On 08/03/2017 at 15:13:40 +0000, Kalle Valo wrote:
> Alexandre Belloni <alexandre.belloni@free-electrons.com> wrote:
> > last_qual never really holds a time. It only holds jiffies. Make it the
> > same type as jiffies.
> > 
> > Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
> 
> The title should start with "atmel:", I can fix that during commit.
> 

If you prefer, I can send a v2

-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
