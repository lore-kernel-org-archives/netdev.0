From: "Sebastian Piecha" <spi@gmxpro.de>
Subject: Re: oops in skbuff.c
Date: Wed, 29 Oct 2003 18:00:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA0003A.25544.4BACBCA@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Everything works now. skbuff.c seems to be ok.

At the end it seems to be an issue between one of my three memory 
modules and the installed Promise ide controller. Without the Promise 
controller everythink works and with a changed memory stick also 
everything works. I did a lot of memtests but no error was shown. I 
think one of the memory modules has some electrical specialties when 
used together with the Promise controller.

Thanks a lot to everybody who tried to shed some light on this.

--
Mit freundlichen Gruessen/Best regards,
Sebastian Piecha

EMail: spi@gmxpro.de
