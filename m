From: James Morris <jmorris@redhat.com>
Subject: Re: Fw: ipsec hang
Date: Wed, 24 Nov 2004 17:30:20 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411241729550.19791-100000@thoron.boston.redhat.com>
References: <41A4CEB1.7000001@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, <netdev@oss.sgi.com>,
        =?ISO-8859-1?Q?Marcin_Gibu=B3a?= <mg@iceni.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41A4CEB1.7000001@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004, Patrick McHardy wrote:

> This patch fixes it. When a policy with a priority lower than an
> existing policy is inserted, it loops forever on the existing policy.

I wonder if it's the same bug as 
http://bugme.osdl.org/show_bug.cgi?id=3796


- James
-- 
James Morris
<jmorris@redhat.com>
