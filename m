From: "David S. Miller" <davem@redhat.com>
Subject: Re: Update on e1000 troubles (over-heating!)
Date: Sun, 06 Oct 2002 22:26:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021006.222633.92515528.davem@redhat.com>
References: <Pine.GSO.4.30.0210061835350.1861-100000@shell.cyberus.ca>
	<3DA103A2.1060901@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, andre@pyxtechnologies.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3DA103A2.1060901@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Sun, 06 Oct 2002 20:46:42 -0700
   
   Dave says I'm wierd and no one else sees these bizarre problems, btw :)
   
The only case where I'm really concerned about the health
of your PCI controller is the most recent case you've
reported to me where pci_find_capability(pdev, PCI_CAP_ID_PM)
fails.  That is just completely bizarre.

I hope your boards aren't being permanently harmed by your box which
is overheating.:(
