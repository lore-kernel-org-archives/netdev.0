From: "Ethy H. Brito" <ethy@inexo.com.br>
Subject: Re: shaper.c (fwd)
Date: Tue, 24 Feb 2004 12:18:41 -0300 (BRT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402241214110.566@node1.inexo.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello

Is anybody in here? I was directed to this email by Mr. Allan Cox.
Is this a maillist (i'm not a subscriber - directions please if so) or it is
a human driven mailbox?
I need to "talk" about a problem in the kernel shaper.c module.

Regards


Ethy H. Brito         /"\
InterNexo Ltda.       \ /  CAMPANHA DA FITA ASCII - CONTRA MAIL HTML
+55 (12) 3941-6860     X   ASCII RIBBON CAMPAIGN - AGAINST HTML MAIL
S.J.Campos - Brasil   / \

---------- Forwarded message ----------
Date: Sat, 21 Feb 2004 17:48:03 -0500
From: Alan Cox <alan@redhat.com>
To: Ethy H. Brito <ethy@inexo.com.br>
Cc: Alan Cox <alan@redhat.com>
Subject: Re: shaper.c

On Fri, Feb 20, 2004 at 07:21:29PM -0300, Ethy H. Brito wrote:
> The listing stays several minutes (up to one hour or so) without any drops and
> then drops a few packets. I couldn't spot why.
>
> Does this ring any bell to you?
> SHAPERCB(skb)->shapeclock been zero smells bad?

It certainly shouldnt be, but I've not dealt with the code since 2.2 so Im
not sure how it has changed to break this. Asking netdev@oss.sgi.com may be
better
