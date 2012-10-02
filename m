From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net, 3/3] hyperv: Fix page buffer handling in
 rndis_filter_send_request()
Date: Tue, 2 Oct 2012 11:38:47 +0300
Message-ID: <20121002083847.GR4587@mwanda>
References: <1349130657-7987-1-git-send-email-haiyangz@microsoft.com>
 <1349130657-7987-3-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1349130657-7987-3-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Oct 01, 2012 at 03:30:57PM -0700, Haiyang Zhang wrote:
> Add another page buffer if the request message crossed page boundary.
> 

What are the user visible effects of this bug fix?  Please put that
in the commit message.

regards,
dan carpenter
