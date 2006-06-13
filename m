From: Patrick McHardy <kaber@trash.net>
Subject: Re: http://bugzilla.kernel.org/show_bug.cgi?id=6197
Date: Tue, 13 Jun 2006 17:57:25 +0200
Message-ID: <448EE065.9060207@trash.net>
References: <20060611055132.2930b95f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:31742 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932159AbWFMP51
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 11:57:27 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060611055132.2930b95f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> The reporter claims this is a netfilter bug.
> 

ipt_IMQ                 1949  36
imq                     4023  0

He patched his kernel with the IMQ device, which is known to cause all
kinds of weird problems.
