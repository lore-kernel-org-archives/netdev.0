From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 08/14] xen: netback: Remove redundant check
 on unsigned variable
Date: Wed, 2 Jan 2013 16:40:04 -0500
Message-ID: <20130102214003.GA15833@phenom.dumpdata.com>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
 <1353048646-10935-9-git-send-email-tushar.behera@linaro.org>
 <1353057394.3499.159.camel@zakaz.uk.xensource.com>
 <50DD2AFB.6030701@linaro.org>
 <1356691292.2917.9.camel@iceland>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tushar Behera <tushar.behera@linaro.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"patches@linaro.org" <patches@linaro.org>
To: Wei Liu <Wei.Liu2@citrix.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26333 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803Ab3ABVkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 16:40:19 -0500
Content-Disposition: inline
In-Reply-To: <1356691292.2917.9.camel@iceland>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 10:41:32AM +0000, Wei Liu wrote:
> On Fri, 2012-12-28 at 05:15 +0000, Tushar Behera wrote:
> > On 11/16/2012 02:46 PM, Ian Campbell wrote:
> > > On Fri, 2012-11-16 at 06:50 +0000, Tushar Behera wrote:
> > >> No need to check whether unsigned variable is less than 0.
> > >>
> > >> CC: Ian Campbell <ian.campbell@citrix.com>
> > >> CC: xen-devel@lists.xensource.com
> > >> CC: netdev@vger.kernel.org
> > >> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
> > > 
> > > Acked-by: Ian Campbell <ian.campbell@citrix.com>
> > > 
> > > Thanks.
> > > 
> > 
> > This patch was not picked up for 3.8-rc1. Any idea, who should pick this up?
> 
> CC'ing Konrad.
> 

And CC-ing the network maintainer. David, Ian (who is the sub-maintainer
of xen-netback) has Acked the patch.

I can put this in my queue if you would like.
