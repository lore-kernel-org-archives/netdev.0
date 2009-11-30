From: Jon Masters <jcm@redhat.com>
Subject: Re: [PROPOSAL]: Support Alternate Network Device Naming Schemes
Date: Mon, 30 Nov 2009 12:07:24 -0500
Message-ID: <1259600844.6978.35.camel@tonnant>
References: <20091127094257.GA24624@mock.linuxdev.us.dell.com>
Reply-To: Discussion of Development and Customization of the Red Hat Linux
	Installer <anaconda-devel-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shyam_iyer@dell.com, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com
To: Discussion of Development and Customization of the Red Hat Linux Installer
	<anaconda-devel-list@redhat.com>
Return-path: <anaconda-devel-list-bounces@redhat.com>
In-Reply-To: <20091127094257.GA24624@mock.linuxdev.us.dell.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/anaconda-devel-list>,
	<mailto:anaconda-devel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/anaconda-devel-list>
List-Post: <mailto:anaconda-devel-list@redhat.com>
List-Help: <mailto:anaconda-devel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/anaconda-devel-list>,
	<mailto:anaconda-devel-list-request@redhat.com?subject=subscribe>
Sender: anaconda-devel-list-bounces@redhat.com
Errors-To: anaconda-devel-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Fri, 2009-11-27 at 03:42 -0600, Narendra K wrote:
> We have been having discussions in the netdev list about creating multiple names for the network interfaces to bring determinism into the way network interfaces are named in the OSes. In specific, "eth0 in the OS does not always map to the integrated NIC Gb1 as labelled on the chassis".  
> 
> http://marc.info/?l=linux-netdev&m=125510301513312&w=2 - (Re: PATCH: Network Device Naming mechanism and policy)
> http://marc.info/?l=linux-netdev&m=125619338904322&w=2 - ([PATCH] udev: create empty regular files to represent net)
> 
> As a result of those discussions, we propose an installer based solution.

Very cool. Thanks for your continued hard work on this stuff :) Do you
have proof of concept Anaconda patches available?

Jon.
