From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sat, 24 Apr 2004 21:13:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040424211339.A29355@electric-eye.fr.zoreil.com>
References: <408A8252.5040006@stanford.edu> <OFD9C928E8.B270E69A-ON87256E80.0069EECE-86256E80.006C0C7E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@stanford.edu>, jgarzik@pobox.com,
        Andy Lutomirski <luto@myrealbox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFD9C928E8.B270E69A-ON87256E80.0069EECE-86256E80.006C0C7E@us.ibm.com>; from jonmason@us.ibm.com on Sat, Apr 24, 2004 at 02:44:59PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> :
[...]
> Looks like a fair amount of work to convert 8139cp to r8169.  Let me know 
> if you need any help.

Actually it is meant to be done in the opposite direction so as to avoid
to duplicate most of the 8139cp driver in the r8169 driver.

--
Ueimor
