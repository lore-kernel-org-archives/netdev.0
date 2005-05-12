From: Jonathan Day <imipak@yahoo.com>
Subject: Questions wrt QoS code on Linux
Date: Wed, 11 May 2005 21:40:39 -0700 (PDT)
Message-ID: <20050512044040.61360.qmail@web31504.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Wondering if someone can answer a few questions on the
QoS code in Linux.

First off, I notice that all the code is lumped
together and much of it is generically labelled
"scheduling". I'm wondering if it might not be more
readable if the list were divided into four sections -
"queueing disciplines", "scheduling", "packet
classification" and "everything else". Would that seem
sensible? Or would it risk making things
over-structured?

Secondly, there seem to be an awful lot of QoS methods
not represented in Linux. Implementing them all might
easily double the kernel size for not very much
benefit, even if anyone could find the time to do so.
On the other hand, there are probably some that are
under development and others high on the wishlist.
Does anyone know what projects are currently underway
or being planned?

Jonathan


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - Helps protect you from nasty viruses. 
http://promotions.yahoo.com/new_mail
