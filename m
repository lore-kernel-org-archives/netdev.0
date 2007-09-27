From: Mohammad M Molla <merajul_i@yahoo.com>
Subject: Re: Linux networking implementation and packet capture
Date: Thu, 27 Sep 2007 01:05:20 -0700 (PDT)
Message-ID: <417515.43841.qm@web53204.mail.re2.yahoo.com>
References: <1a41e0840709262347m1fc5d99dge9aeb172b7fc610e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-190942869-1190880320=:43841"
Content-Transfer-Encoding: 8bit
To: Gaurav Aggarwal <grv.aggarwal@gmail.com>, kernelnewbies@nl.linux.org,
  linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <kernelnewbies-bounce@nl.linux.org>
In-Reply-To: <1a41e0840709262347m1fc5d99dge9aeb172b7fc610e@mail.gmail.com>
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

--0-190942869-1190880320=:43841
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

There are two good books that you might find useful - 

1. Understanding Linux Network Internals - Christian Benvenuti
2. The Linux TCP/IP stack - Networking for Embedded Systems - Thomas F. Herbert

- Meraj

Gaurav Aggarwal <grv.aggarwal@gmail.com> wrote: Hi,

I am trying to understand the implementation of linux 2.4 and linux 2.6's networking (IPV4) . Can anyone give me some idea/pointers about some of the good resources/whitepapers available in the market to understand the same. If there is any document that mention the changes between the implementation of networking in  2.4 & 2.6

I am also trying to write a simple program(preferably a userspace application) which captures all the incoming and outgoing packets of a particular machine (preferably at PREROUTING stage), then according to the SRC/DST addresses, changes the IP address of some of the packets and then reinject it back into the local IP stack. I am able to do that in  2.4 kernel by using libipq and ip_tables but that prog is not running in 2.6 kernel. (It hits at ip_route_BUG). Any idea or code snippet will be really appreciated.

-- 
Regards,
Gaurav Aggarwal

 

       
---------------------------------
Need a vacation? Get great deals to amazing places on Yahoo! Travel. 
--0-190942869-1190880320=:43841
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

There are two good books that you might find useful - <br><br>1. Understanding Linux Network Internals - Christian Benvenuti<br>2. The Linux TCP/IP stack - Networking for Embedded Systems - Thomas F. Herbert<br><br>- Meraj<br><br><b><i>Gaurav Aggarwal &lt;grv.aggarwal@gmail.com&gt;</i></b> wrote:<blockquote class="replbq" style="border-left: 2px solid rgb(16, 16, 255); margin-left: 5px; padding-left: 5px;"> Hi,<br><br>I am trying to understand the implementation of linux 2.4 and linux 2.6's networking (IPV4) . Can anyone give me some idea/pointers about some of the good resources/whitepapers available in the market to understand the same. If there is any document that mention the changes between the implementation of networking in  2.4 &amp; 2.6<br><br>I am also trying to write a simple pr
 ogram(preferably a userspace application) which captures all the incoming and outgoing packets of a particular machine (preferably at PREROUTING stage), then according to the SRC/DST
 addresses, changes the IP address of some of the packets and then reinject it back into the local IP stack. I am able to do that in  2.4 kernel by using libipq and ip_tables but that prog is not running in 2.6 kernel. (It hits at ip_route_BUG). Any idea or code snippet will be really appreciated.<br><br>-- <br>Regards,<br>Gaurav Aggarwal<br><br> </blockquote><br><p>&#32;
      <hr size=1>Need a vacation? <a href="http://us.rd.yahoo.com/evt=48256/*http://travel.yahoo.com/;_ylc=X3oDMTFhN2hucjlpBF9TAzk3NDA3NTg5BHBvcwM1BHNlYwNncm91cHMEc2xrA2VtYWlsLW5jbQ--">Get great deals 
to amazing places </a>on Yahoo! Travel. 
--0-190942869-1190880320=:43841--

--
To unsubscribe from this list: send an email with
"unsubscribe kernelnewbies" to ecartis@nl.linux.org
Please read the FAQ at http://kernelnewbies.org/FAQ
