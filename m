From: James Morris <jmorris@redhat.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 19:16:16 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409151914400.32649-100000@thoron.boston.redhat.com>
References: <Pine.NEB.4.33.0409151704200.5383-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netdev <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409151704200.5383-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, John Heffner wrote:

> The other (much nicer) solution to case (b) is to just USE A BIGGER MTU.
> 1500 bytes is ridiculously small.  Even with a 9k MTU, the benefits of TOE
> or TSO are nearly vanishing.

Do you have any figures on (large) MTU size vs performance on a current
commidity system?


- James
-- 
James Morris
<jmorris@redhat.com>
