From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sun, 25 Apr 2004 16:09:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF82CB6DE.E6133152-ON87256E81.007259F5-86256E81.0073C48D@us.ibm.com>
References: <20040424050931.14C341D4F@luto.stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com, romieu@fr.zoreil.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040424050931.14C341D4F@luto.stanford.edu>
To: Andy Lutomirski <luto@myrealbox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hey Andy,
I hand patched my driver (which is probably my mistake), and I noticed a 
great increase in bring-up time.  Good job!

I noticed that the new driver never logs my speed in the dmesg (like the 
old driver did).  I could use ethtool, but I'm all about backwards 
compatibility.  So, it might be a good idea to have it in there too.

Thanks,
Jon
