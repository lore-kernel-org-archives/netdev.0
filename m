From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyper-v: make uuid_le const
Date: Tue, 03 Jun 2014 18:19:51 -0700 (PDT)
Message-ID: <20140603.181951.805355116378664370.davem@davemloft.net>
References: <20140603083815.14688f8a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140603083815.14688f8a@nehalam.linuxnetplumber.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 3 Jun 2014 08:38:15 -0700

> The uuid structure could be managed as a const in several places.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
