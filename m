From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Wed, 28 Jan 2004 12:15:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF7C2C0CBA.2EB2CB3B-ON87256E29.006F1965@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4BADFFC9FF58f9e8a93df938690918c08BBE4BADFFC9FF5"
Cc: "David S. Miller" <davem@redhat.com>, Krishna Kumar <kumarkr@us.ibm.com>,
        kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4BADFFC9FF58f9e8a93df938690918c08BBE4BADFFC9FF5
Content-type: text/plain; charset=US-ASCII





This solution doesn't favor writers also. How about do some udelay in the
reader to avoid modifing the writers?

Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
--0__=08BBE4BADFFC9FF58f9e8a93df938690918c08BBE4BADFFC9FF5
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>This solution doesn't favor writers also. How about do some udelay in the reader to avoid modifing the writers?<br>
<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
</body></html>
--0__=08BBE4BADFFC9FF58f9e8a93df938690918c08BBE4BADFFC9FF5--
