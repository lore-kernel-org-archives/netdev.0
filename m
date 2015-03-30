From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net-next 1/2] hv_netvsc: Cleanup the test for freeing skb
 when we use sendbuf mechanism
Date: Mon, 30 Mar 2015 12:02:34 +0300
Message-ID: <20150330090234.GC10964@mwanda>
References: <1427688478-27950-1-git-send-email-kys@microsoft.com>
 <1427688522-27991-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1427688522-27991-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Sun, Mar 29, 2015 at 09:08:41PM -0700, K. Y. Srinivasan wrote:
> In preparation for embedding the rndis state and other packet state into
> the skb, cleanup the test for freeing the skb.
> 

So there is no behavior change in applying this patch?

regards,
dan carpenter
