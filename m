From: "Gaurav Aggarwal" <grv.aggarwal@gmail.com>
Subject: Linux networking implementation and packet capture
Date: Thu, 27 Sep 2007 12:17:49 +0530
Message-ID: <1a41e0840709262347m1fc5d99dge9aeb172b7fc610e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_352_14324444.1190875669080"
To: kernelnewbies@nl.linux.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <kernelnewbies-bounce@nl.linux.org>
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

------=_Part_352_14324444.1190875669080
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I am trying to understand the implementation of linux 2.4 and linux 2.6's
networking (IPV4) . Can anyone give me some idea/pointers about some of the
good resources/whitepapers available in the market to understand the same.
If there is any document that mention the changes between the implementation
of networking in 2.4 & 2.6

I am also trying to write a simple program(preferably a userspace
application) which captures all the incoming and outgoing packets of a
particular machine (preferably at PREROUTING stage), then according to the
SRC/DST addresses, changes the IP address of some of the packets and then
reinject it back into the local IP stack. I am able to do that in 2.4 kernel
by using libipq and ip_tables but that prog is not running in 2.6 kernel.
(It hits at ip_route_BUG). Any idea or code snippet will be really
appreciated.

-- 
Regards,
Gaurav Aggarwal

------=_Part_352_14324444.1190875669080
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br><br>I am trying to understand the implementation of linux 2.4 and linux 2.6&#39;s networking (IPV4) . Can anyone give me some idea/pointers about some of the good resources/whitepapers available in the market to understand the same. If there is any document that mention the changes between the implementation of networking in 
2.4 &amp; 2.6<br><br>I am also trying to write a simple program(preferably a userspace application) which captures all the incoming and outgoing packets of a particular machine (preferably at PREROUTING stage), then according to the SRC/DST addresses, changes the IP address of some of the packets and then reinject it back into the local IP stack. I am able to do that in 
2.4 kernel by using libipq and ip_tables but that prog is not running in 2.6 kernel. (It hits at ip_route_BUG). Any idea or code snippet will be really appreciated.<br><br>-- <br>Regards,<br>Gaurav Aggarwal<br><br>

------=_Part_352_14324444.1190875669080--

--
To unsubscribe from this list: send an email with
"unsubscribe kernelnewbies" to ecartis@nl.linux.org
Please read the FAQ at http://kernelnewbies.org/FAQ
