From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Mon, 21 Feb 2005 09:16:19 +0100
Message-ID: <20050221081619.GA18754@electric-eye.fr.zoreil.com>
References: <200502161823.43562.jdmason@us.ibm.com> <200502201204.23468.jdmason@us.ibm.com> <20050220233405.GA14268@electric-eye.fr.zoreil.com> <200502202254.23511.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200502202254.23511.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> My main problem with the above patch is that is assumes that there will
> be a maximum of 2 descriptors per jumbo frame (which isn't the case). 

Where do you see such an assumption ?

--
Ueimor
