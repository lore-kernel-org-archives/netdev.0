From: Shirley Ma <xma@us.ibm.com>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 15:56:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com>
References: <20040309152932.36a42997.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4C1DF10BA948f9e8a93df938690918c08BBE4C1DF10BA94"
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com, Olaf Kirch <okir@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040309152932.36a42997.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4C1DF10BA948f9e8a93df938690918c08BBE4C1DF10BA94
Content-type: text/plain; charset=US-ASCII





Hi, Dave,

This fix causes a problem for SNMP IPv6 MIBs. It requires to dump all
interface
address types unicast/mcast/anycast. I would like suggest to fix the ip
command to fix the problem.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
--0__=08BBE4C1DF10BA948f9e8a93df938690918c08BBE4C1DF10BA94
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Hi, Dave,<br>
<br>
This fix causes a problem for SNMP IPv6 MIBs. It requires to dump all interface <br>
address types unicast/mcast/anycast. I would like suggest to fix the ip <br>
command to fix the problem.<br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228</body></html>
--0__=08BBE4C1DF10BA948f9e8a93df938690918c08BBE4C1DF10BA94--
