From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
	master'ssettings toslaves
Date: 12 Aug 2003 10:29:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060698553.1063.11.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A0251E69F@hasmsx403.iil.intel.com>
	 <200308121703.15567.shmulik.hen@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, laurent.deniel@thalesatm.com,
   jgarzik@pobox.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308121703.15567.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-08-12 at 10:03, Shmulik Hen wrote:

> 
> What scope are we talking about here ?
> 2.4 ?  2.6 ?  2.7 ?  other ?
> Our current aim is 2.4 and 2.6.
> 

You should start thinking 2.7. 

> Taking into account the two statements I made above:
> Do you think that what we're doing right now might interfere with what 
> Jamal is suggesting ?
> Wouldn't it be possible to do things the old way first and than 
> convert everything to the new way ?
> Shouldn't all this be a part of a totally new project like "bonding2"

yes, this would be next gen - 2.7 or above target.

cheers,
jamal
