From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Sat, 19 Mar 2005 16:23:54 +0100
Message-ID: <20050319152354.GA4946@electric-eye.fr.zoreil.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com> <200503182333.51470.jdmason@us.ibm.com> <efe3b0060503190229dff2a01@mail.gmail.com> <200503190757.27727.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kosta Todorovic <kostodo@gmail.com>, Ben Greear <greearb@candelatech.com>,
        jgarzik@pobox.com, tulip-users@lists.sourceforge.net,
        netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200503190757.27727.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> The ZNXY website provides the driver source for the 4port adapter (and it is 
> GPL'ed), but it seems to me that this is really an issue of getting the 
> adapter to work with the "real" kernel driver, tulip.

There are no sources for the rlk.O file and the driver suffers a bit from
the usual out-of-tree hal braindamage. Both can probably be worked around
but I would not make my business depend on the availability of a sane
driver within a reasonable timescale.

--
Ueimor
