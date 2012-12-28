From: Wei Liu <Wei.Liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 08/14] xen: netback: Remove redundant check
 on unsigned variable
Date: Fri, 28 Dec 2012 10:41:32 +0000
Message-ID: <1356691292.2917.9.camel@iceland>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
	 <1353048646-10935-9-git-send-email-tushar.behera@linaro.org>
	 <1353057394.3499.159.camel@zakaz.uk.xensource.com>
	 <50DD2AFB.6030701@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"patches@linaro.org" <patches@linaro.org>, <konrad.wilk@oracle.com>
To: Tushar Behera <tushar.behera@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50DD2AFB.6030701@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-12-28 at 05:15 +0000, Tushar Behera wrote:
> On 11/16/2012 02:46 PM, Ian Campbell wrote:
> > On Fri, 2012-11-16 at 06:50 +0000, Tushar Behera wrote:
> >> No need to check whether unsigned variable is less than 0.
> >>
> >> CC: Ian Campbell <ian.campbell@citrix.com>
> >> CC: xen-devel@lists.xensource.com
> >> CC: netdev@vger.kernel.org
> >> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
> > 
> > Acked-by: Ian Campbell <ian.campbell@citrix.com>
> > 
> > Thanks.
> > 
> 
> This patch was not picked up for 3.8-rc1. Any idea, who should pick this up?

CC'ing Konrad.
