From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 6 Sep 2002 17:38:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15736.52203.840229.604858@robur.slu.se>
References: <15736.38178.445310.714015@robur.slu.se>
	<46676537.1031297834@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "David S. Miller" <davem@redhat.com>, akpm@zip.com.au, hadi@cyberus.ca,
   tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
In-Reply-To: <46676537.1031297834@[10.10.2.3]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Martin J. Bligh writes:


 > We are running from 2.5.latest ... any updates needed for NAPI for the
 > driver in the current 2.5 tree, or is that OK?

 Should be OK. Get latest kernel e1000 to get Intel's and maintainers latest 
 work and apply the e1000 NAPI patch. RH includes this patch?

 And yes there are plenty of room for improvements...


 Cheers.
						--ro
