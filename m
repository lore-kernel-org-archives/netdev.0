From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next] net: phy: xgmiitorgmii: Fix non static symbol
 warning
Date: Tue, 23 Aug 2016 17:50:09 +0200
Message-ID: <20160823155009.GM20029@lunn.ch>
References: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
 <20160823151619.GK20029@lunn.ch>
 <874c4fd0-ac5d-9db0-3470-e092b9251cd7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, michal.simek@xilinx.com,
 Wei Yongjun <weiyongjun1@huawei.com>, soren.brinkmann@xilinx.com,
 linux-arm-kernel@lists.infradead.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <874c4fd0-ac5d-9db0-3470-e092b9251cd7@gmail.com>
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

On Tue, Aug 23, 2016 at 11:41:25PM +0800, Wei Yongjun wrote:
> Hi Andrew,
> 
> On 08/23/2016 11:16 PM, Andrew Lunn wrote:
> > On Tue, Aug 23, 2016 at 03:06:05PM +0000, Wei Yongjun wrote:
> >> From: Wei Yongjun <weiyongjun1@huawei.com>
> > Hi Wei
> >
> > No need for the additional From:
> >
> > git am will use the one in the mail header as the author of the patch,
> > and it is in the signed-off-by as well.
> 
> The mail address which I sent the patch is different with the
> signed-of-by one, so git send-email will not remove the From line.

Cool. git am strips it out of the commit message and uses it as the
Author. I didn't know it did that.

Sorry for the noise, 

	Andrew
