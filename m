From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 12:45:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <65179883.1031316338@[10.10.2.3]>
References: <1031339954.3d78ffb257d22@imap.linux.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>, Andi Kleen <ak@suse.de>
In-Reply-To: <1031339954.3d78ffb257d22@imap.linux.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Tthere is some cacheline thrashing hurting the NUMA 
> more than other systems here too..

There is no NUMA here ... the clients are 4 single node SMP 
systems. We're using the old quads to make them, but they're 
all split up, not linked together into one system.
Sorry if we didn't make that clear.

M.
