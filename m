From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] netconsole: fix NULL pointer dereference
Date: Sat, 26 Oct 2013 01:06:51 +0200
Message-ID: <20131025230651.GA14658@electric-eye.fr.zoreil.com>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com>
 <20131024102147.GD16787@redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com>
 <20131024.135614.1725589105857635534.davem@davemloft.net>
 <52696563.1060507@redhat.com>
 <20131024205934.GA26855@electric-eye.fr.zoreil.com>
 <526A7CE5.8040205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	vfalico@redhat.com, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57019 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935Ab3JYXHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:07:03 -0400
Content-Disposition: inline
In-Reply-To: <526A7CE5.8040205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> :
[...]
> I thought this implies that the spinlock protects us against running with
> write_msg().
> It's fine by me either way (with or w/o the addition to the comment). It's
> up to you Dave, do you still want it explicitly there ?

There was some facetiousness in David's comment.

-- 
Ueimor
