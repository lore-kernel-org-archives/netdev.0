From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Sat, 19 Mar 2005 07:57:27 -0600
Message-ID: <200503190757.27727.jdmason@us.ibm.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com> <200503182333.51470.jdmason@us.ibm.com> <efe3b0060503190229dff2a01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b0060503190229dff2a01@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 19 March 2005 04:29 am, Kosta Todorovic wrote:
> Problem is that all the adapters are currently in use in 32bit mode.
> It was my only solution. I'm hoping that will not be a permanent
> thing.
> Im just a little lost as in to what I should do.
>
> I've been told by ZNXY that they *might* provide the source code to
> the entire driver, so if there is someone that is willing to try make
> it work I would be eternally greatful.

I have a tulip adapter laying around somewhere.  I can give that a try and 
verify that tulip works on a 64bit system (assuming it hasn't been already 
tried).  

The ZNXY website provides the driver source for the 4port adapter (and it is 
GPL'ed), but it seems to me that this is really an issue of getting the 
adapter to work with the "real" kernel driver, tulip.

Thanks,
Jon
