From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: patch for common networking error messages
Date: 23 Jun 2003 12:54:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056369251.13529.17.camel@dhcp22.swansea.linux.org.uk>
References: <OFC2446DB8.6D4DA3ED-ON85256D47.007C79EE@us.ibm.com>
	 <20030616.155533.63022973.davem@redhat.com>
	 <1056199013.25974.27.camel@dhcp22.swansea.linux.org.uk>
	 <20030622.174641.74727201.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: girouard@us.ibm.com, stekloff@us.ibm.com, janiceg@us.ibm.com,
   jgarzik@pobox.com, kenistonj@us.ibm.com, lkessler@us.ibm.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030622.174641.74727201.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Llu, 2003-06-23 at 01:46, David S. Miller wrote:
>    From: Alan Cox <alan@lxorguk.ukuu.org.uk>
>    Date: 21 Jun 2003 13:36:54 +0100
>    
>    Standardising strings is a real help for end users,
> 
> I agree.  But my objections are in the context of doing this
> inside the kernel, where such things do not belong.

Standardising strings for end users in the kernel is also good
because it both saves space and makes things more consistent for
the poor human wondering what blew up.

Standardising them for programs to parse is not a good idea
