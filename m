From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 4/8] xenbus_client: Extend interface to
 support multi-page ring
Date: Fri, 15 Feb 2013 16:59:13 +0000
Message-ID: <511E777102000078000BEDFF@nat28.tlf.novell.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
 <511E6D9702000078000BED23@nat28.tlf.novell.com>
 <1360945999.16636.169.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"Roger PauMonne" <roger.pau@citrix.com>,
	"Stefano Stabellini" <Stefano.Stabellini@eu.citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:45382 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab3BOQ7T convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 15 Feb 2013 11:59:19 -0500
In-Reply-To: <1360945999.16636.169.camel@zion.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 15.02.13 at 17:33, Wei Liu <wei.liu2@citrix.com> wrote:
> On Fri, 2013-02-15 at 16:17 +0000, Jan Beulich wrote:
>> >>> On 15.02.13 at 17:00, Wei Liu <wei.liu2@citrix.com> wrote:
>> > Also bundle fixes for xen frontends and backends in this patch.
>> 
>> Could you at least enumerate those fixes in the patch description?
> 
> Mostly mechanical fixes to adapt to new xenbus client interface, which
> includes: xen-pciback, xen-pcifront, xen-blkback, xen-blkfront,
> xen-netback, xen-netfront.

But "fixes" and "changes" are two different terms.

Jan
