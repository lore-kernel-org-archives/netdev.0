From: Simon Graham <simon.graham@citrix.com>
Subject: RE: [PATCH] xen/netback: calculate correctly the SKB slots.
Date: Wed, 23 May 2012 10:17:58 -0400
Message-ID: <F02ED76F3FCF8C468AD22A7618C05BBBB18DBFFFA4@FTLPMAILBOX01.citrite.net>
References: <1337621793-12486-1-git-send-email-konrad.wilk@oracle.com>
 <1337627640.2979.33.camel@bwh-desktop.uk.solarflarecom.com>
 <1337678512.10118.40.camel@zakaz.uk.xensource.com>
 <20120522180901.GC22488@phenom.dumpdata.com>
 <F02ED76F3FCF8C468AD22A7618C05BBBB18DBFFE61@FTLPMAILBOX01.citrite.net>
 <20120523131242.GA15406@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Adnan Misherfi <adnan.misherfi@oracle.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24092 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932239Ab2EWOS2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 10:18:28 -0400
In-Reply-To: <20120523131242.GA15406@phenom.dumpdata.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > We ran into this same problem and the fix we've been running with for
> a while now (been meaning to submit it!) is:
> 
> Where is the patchqueue of the patches? Is it only on the src.rpm or
> is it in some nice mercurial tree? Asking b/c if we run into other
> trouble
> it would be also time-saving for us (and I presume other companies
> too) to check that. Thanks!

Currently our patchqueue is only in the source iso and not in an externally visible git tree - sorry!

Simon
