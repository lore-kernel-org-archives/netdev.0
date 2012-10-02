From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net, 3/3] hyperv: Fix page buffer handling in
 rndis_filter_send_request()
Date: Tue, 2 Oct 2012 14:28:25 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DE326F6@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1349130657-7987-1-git-send-email-haiyangz@microsoft.com>
 <1349130657-7987-3-git-send-email-haiyangz@microsoft.com>
 <20121002083847.GR4587@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20121002083847.GR4587@mwanda>
Content-Language: en-US
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



> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Tuesday, October 02, 2012 4:39 AM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net, 3/3] hyperv: Fix page buffer handling in
> rndis_filter_send_request()
> 
> On Mon, Oct 01, 2012 at 03:30:57PM -0700, Haiyang Zhang wrote:
> > Add another page buffer if the request message crossed page boundary.
> >
> 
> What are the user visible effects of this bug fix?  Please put that
> in the commit message.

Will do.

Thanks,
- Haiyang
