From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Sun, 22 Jun 2003 17:46:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030622.174641.74727201.davem@redhat.com>
References: <OFC2446DB8.6D4DA3ED-ON85256D47.007C79EE@us.ibm.com>
	<20030616.155533.63022973.davem@redhat.com>
	<1056199013.25974.27.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: girouard@us.ibm.com, stekloff@us.ibm.com, janiceg@us.ibm.com,
   jgarzik@pobox.com, kenistonj@us.ibm.com, lkessler@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1056199013.25974.27.camel@dhcp22.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alan Cox <alan@lxorguk.ukuu.org.uk>
   Date: 21 Jun 2003 13:36:54 +0100
   
   Standardising strings is a real help for end users,

I agree.  But my objections are in the context of doing this
inside the kernel, where such things do not belong.
