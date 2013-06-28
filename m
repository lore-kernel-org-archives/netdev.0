From: "Jan Beulich" <JBeulich@suse.com>
Subject: your patch "netback: set transport header before passing it to
 kernel"
Date: Fri, 28 Jun 2013 11:09:40 +0100
Message-ID: <51CD7D0402000078000E1829@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>,
	"xen-devel" <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
To: <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:41691 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879Ab3F1KJm convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Fri, 28 Jun 2013 06:09:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason,

is there any reason why the same isn't needed in netfront?

Thanks, Jan
