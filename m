From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 14:39:59 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029033959.B76CD12CE75__16610.6787430637$1035867519@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The e1000 can very well do hardware checksumming on transmit.
>
> The missing piece of the puzzle is that his application is not
> using sendfile(), without which no transmit checksum offload
> can take place.

As far as I've understood, sendfile() won't do much good with large files. Is 
this right?

We're talking of 3-6GB files here ...

roy
-- 
Roy Sigurd Karlsbakk, Datavaktmester
ProntoTV AS - http://www.pronto.tv/
Tel: +47 9801 3356

Computers are like air conditioners.
They stop working when you open Windows.
