From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [ofa-general] Re: [PATCH 0/26] Reliable Datagram Sockets (RDS),
	take 2
Date: Wed, 25 Feb 2009 10:04:09 +0200
Message-ID: <49A4FB79.1090809@voltaire.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<20090224.232814.227017310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090224.232814.227017310.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> Major changes since last time include moving to net/rds, and the additional inclusion of iwarp transport support.
>>     
> This makes RDMA too much of a first-class citizen in the networking stack.  That's a blocker for me.
>   
Hi Dave

Can you elaborate a bit further, I wasn't sure to follow if your comment 
was related to the inclusion of iwarp or to something else.

Or.
