From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: 3c59x support
Date: Tue, 29 Apr 2003 13:46:23 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304291341200.2895-100000@kenzo.iwr.uni-heidelberg.de>
References: <200304290202.02811.borkdude@cs.utwente.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: andrewm@uow.edu.au, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michiel Borkent <borkdude@cs.utwente.nl>
In-Reply-To: <200304290202.02811.borkdude@cs.utwente.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[ dropped linux-kernel ]

On Tue, 29 Apr 2003, Michiel Borkent wrote:

> card and it only works with the 3c59x-scyld module, I found with Debian
> Woody with a linux v2.2 kernel.

What version of the Scyld driver are you using ?
Please note that the Scyld driver works with the 2.4 kernels too.

> It does NOT work with the normal 3c59x module

Well, "does NOT work" is not really a good starting point for a diagnosis.
You should find in Documentation/networking/vortex.txt in your kernel tree 
details about how to create a useful report.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
