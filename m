From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: arp table flushed!
Date: Thu, 03 Mar 2005 13:23:43 -0500
Message-ID: <4227562F.5000603@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I wonder if you know why when I do a L3 handoff (the IP address changes) 
the arp table is completely flushed. So, the kernel starts to arp all 
over again.
Do you know if there is a way to prevent the arp table from being 
cleaned? I tried to re-fill the entries manually (using the arp command) 
after I got the new IP, but the kernel ignores the whole thing and 
starts to arp again.
Any help is much appreciated.

Best regards,
Andrea
