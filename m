From: Ricardo Scop <rscop@matrix.com.br>
Subject: Fwd: Re: GRE tunnel keepalive support?
Date: Tue, 28 Jun 2005 19:34:41 -0300
Message-ID: <200506281934.41732.rscop@matrix.com.br>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, all

Any further development of the subject above? Neither I want to duplicate 
efforts... ;)

Please CC to my private address as I'm not yet subscribed to this list.

Many thanks,

-Scop.

On Tue, Dec 09, 2003 at 10:33:21PM -0800, David S. Miller wrote:
> > > is anybody aware of anyone implementing keepalives for GRE tunnels?
> > > I don't want to duplicate efforts...
> > >
> > > http://www.cisco.com/en/US/products/sw/iosswrel/ps1838/
> > > products_feature_guide09186a0080134a36.html
> >
> > Not to my knowledge.  It looks like a rather simple mechanism,
> > and should be easy to code up.  Feel free.
> 
> OK, anything else than "easy" would be out of scope anyway, given
> significant time constraints and never did any kernel work at all
> (except some micropatches). Given that there is no documentation
> whatsoever, I will have to do some reverse engineering though.
> 
> Best regards,
> Daniel
> 

-- 
Ricardo Scop.

        \|/
    ___ -*-
   (@ @)/|\
  /  V  \|  R SCOP Consult.
 /(     )\  Linux-based communications
--^^---^^+------------------------------
rscop@matrix.com.br
+55 51 999-36-777
Porto Alegre, RS - BRazil
--
P. S.: "If you don't have time to do it right, when will you have time
to do it over?"  -- Penny Hines  
