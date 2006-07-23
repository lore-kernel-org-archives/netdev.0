From: Jeff Garzik <jeff@garzik.org>
Subject: Private driver support emails should be avoided.
Date: Sun, 23 Jul 2006 18:05:58 -0400
Message-ID: <44C3F2C6.5010001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32162 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751325AbWGWWGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2006 18:06:00 -0400
To: "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just a reminder to folks out there...  Don't send private driver support 
emails.

I receive a lot of email.  A lot.  Not as much as Linus or Andrew 
probably, but still sizable.  And quite regularly, I will receive a 
private email asking for help on a SATA or net driver problem.  The 
poster will include various details on their problem, and ask for help 
debugging the problem.  While the email will indeed be skimmed -- 
looking at a mass of bug reports, one can better detect patterns -- the 
people seeking support privately will almost NEVER RECEIVE A RESPONSE.

Unless there is a security issue (email security@kernel.org), posters 
should ALWAYS email their report(s) to one or more mailing lists.

Private email
* is not archived publicly
* is not Google-able
* restricts the sharing of knowledge
* prevents other users from responding to your email

Feel free to CC me on problems you think should warrant my attention.  A 
carbon copy is acceptable to almost all regular kernel contributors.


As another tip, if a kernel bug or annoyance persists, people are 
encouraged to maintain wiki and web pages describing the behavior, and 
discussed problem history.  Maintaining "SATA sucks on ThinkPad" style 
web pages is always a good way to shame kernel hackers into action ;-) 
Maintaining such web pages is a good way for a group of affected users 
to pool common information, and suggested workarounds.

Ensuring the freshness of bugzilla.kernel.org information is also a 
great way for non-kernel hackers to help out.  Sometimes a bug is only 
solved after a pattern emerges from a group of problem reports.  Even 
"me too!" bugzilla reports are helpful...  if they are followed by 
highly detailed hardware and kernel information.

	Jeff



