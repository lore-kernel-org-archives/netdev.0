From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 17:08:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB1A49B9E.7066A43F-ON87256E24.0005F5B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4B7DF9673258f9e8a93df938690918c08BBE4B7DF967325"
Cc: Krishna Kumar <kumarkr@us.ibm.com>, kuznet@ms2.inr.ac.ru,
        mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4B7DF9673258f9e8a93df938690918c08BBE4B7DF967325
Content-type: text/plain; charset=US-ASCII





Do you really care about this situation? It only happens as a race within
one instruction in 4 billion. It will slow everytime if we do this way.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228

--0__=08BBE4B7DF9673258f9e8a93df938690918c08BBE4B7DF967325
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Do you really care about this situation? It only happens as a race within one instruction in 4 billion. It will slow everytime if we do this way. <br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
<br>
</body></html>
--0__=08BBE4B7DF9673258f9e8a93df938690918c08BBE4B7DF967325--
