From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: High CPU utilization with Bonding driver ?
Date: Wed, 13 Apr 2005 14:29:35 -0700
Message-ID: <002101c5406f$e469e5a0$3810100a@pc.s2io.com>
References: <Pine.LNX.4.61.0504042000050.13673@linux.site>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <bonding-devel@lists.sourceforge.net>,
        "'Leonid. Grossman \(E-mail\)'" <leonid.grossman@neterion.com>,
        "'Raghavendra. Koushik \(E-mail\)'" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Arthur Kepner'" <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504042000050.13673@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arthur,
We were able to get the bonding driver working with your patch on 2.6.12.
The good news is it does help in our setup since we were left with 25%
CPU compared to 1% CPU remaining earlier.

Thanks,
Ravi

-----Original Message-----
From: Arthur Kepner [mailto:akepner@sgi.com]
Sent: Monday, April 04, 2005 8:03 PM
To: Ravinandan Arakali
Cc: netdev@oss.sgi.com; bonding-devel@lists.sourceforge.net; 'Leonid.
Grossman (E-mail)'; 'Raghavendra. Koushik (E-mail)'
Subject: RE: High CPU utilization with Bonding driver ?



On Mon, 4 Apr 2005, Ravinandan Arakali wrote:

> Arthur,
> On what kernel version should your below mentioned patch be applied ? 
> We tried on one of the older kernels(2.6.5) and got an Oops while 
> loading the bonding driver.
> .....

Hmmm, interesting. 

I've used it with 2.6.X for at least two values of X (one of them 
being 5) so I'm surprised. Can you provide details about the oops?

--

Arthut
