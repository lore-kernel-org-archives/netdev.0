From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 4/8] xenbus_client: Extend interface to
 support multi-page ring
Date: Fri, 15 Feb 2013 16:17:11 +0000
Message-ID: <511E6D9702000078000BED23@nat28.tlf.novell.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>,
	"Roger Pau Monne" <roger.pau@citrix.com>,
	"Stefano Stabellini" <stefano.stabellini@eu.citrix.com>,
	<xen-devel@lists.xen.org>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:40266 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3BOQRR convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 15 Feb 2013 11:17:17 -0500
In-Reply-To: <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 15.02.13 at 17:00, Wei Liu <wei.liu2@citrix.com> wrote:
> Also bundle fixes for xen frontends and backends in this patch.

Could you at least enumerate those fixes in the patch description?

Jan
