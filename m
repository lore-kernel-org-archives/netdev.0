From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Fri, 23 Apr 2004 15:55:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87u0zare7e.fsf@deneb.enyo.de>
References: <XFMail.20040422102359.pochini@shiny.it>
	<1082640135.1059.93.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuliano Pochini <pochini@shiny.it>, "David S. Miller"
 <davem@redhat.com>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        cfriesen@nortelnetworks.com,
        =?iso-8859-1?q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082640135.1059.93.camel@jzny.localdomain> (hadi@cyberus.ca's
 message of "22 Apr 2004 09:22:16 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

> OTOH, long lived BGP sessions are affected assuming you are going across
> hostile path to your peer.

Jamal, please forget that "hostile path to your peer" part.  It's just
wrong.

You are entitled to your opinion that this isssue is being overhyped
(I tend to share it, at least until some evidence shows up that
there's also a 4.4BSD-like RST bug), but please try to understand the
issue before making any judgement.

-- 
Current mail filters: many dial-up/DSL/cable modem hosts, and the
following domains: atlas.cz, bigpond.com, postino.it, tiscali.co.uk,
tiscali.cz, tiscali.it, voila.fr.
