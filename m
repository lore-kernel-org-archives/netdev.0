From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: batman: keep batman_ogm_packet ->seqno net-endian all along
Date: Wed, 18 Apr 2012 19:15:53 +0100
Message-ID: <20120418181553.GG6589@ZenIV.linux.org.uk>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
 <20120418180837.GB6589@ZenIV.linux.org.uk>
 <20120418181150.GE6589@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39592 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab2DRSPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:15:54 -0400
Content-Disposition: inline
In-Reply-To: <20120418181150.GE6589@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grr... this one would be 3/4 and the last ("trivial endianness annotations") -
4/4.  My apologies...
