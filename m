From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Possible prism54 softmac software
Date: Wed, 23 Jun 2004 10:28:21 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040623142821.GF6253@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


While on  IRC, Viddy informed me that he found the following URLs:

09:15 < Viddy> you guys might like to know this: There is an 802.11g 
with the thin firmware sold by a company in nz,  
http://www.dse.co.nz/cgi-bin/dse.storefront/40d977e1061a835c273fc0a87f990719/Product/View/XH8196
they have some source drivers on thier
webpage here: 
http://www.dse.co.nz/cgi-bin/dse.filereader?40d977e1061a835c273fc0a87f990719+EN/catalogs/SUPXH8196 
with the actual 3meg source
file here: 
http://www.dse.co.nz/isroot/dse/support/XH8196-linux.zip

Quick review shows this could indeed be the Softmac driver source base
that will allow us to support for Prism Xbow/Javelin chipsets. I don't necessarily 
like the license and I also noticed they used pcmcia-cs again (not necessary). 
Anyway, just wanted to relay the information. A lot of work ahead of us.

Please review, poke, poke, etc.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
