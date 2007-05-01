From: Loic Prylli <loic@myri.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Tue, 01 May 2007 15:05:24 -0700
Message-ID: <4637B9A4.2050103@myri.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>	<20070425124652.GG1624@mellanox.co.il>	<6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>	<20070426161409.GF15540@mellanox.co.il>	<6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>	<20070426180618.GJ15540@mellanox.co.il>	<6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>	<46325DF3.2050203@hp.com>	<6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>	<46327A07.1000404@hp.com>	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>	<4632894D.40705@hp.com>	<20070428025117.a3b1200a.billfink@mindspring.com>
	<4634F49F.9030408@myri.com> <46365BD4.5060607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bryan Lawver <lawver1@llnl.gov>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Bill Fink <billfink@mindspring.com>, mst@dev.mellanox.co.il,
	general@lists.openfabrics.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46365BD4.5060607@hp.com>
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

On 4/30/2007 2:12 PM, Rick Jones wrote:
>
> Speaking of defaults, it would seem that the external 1.2.0 driver 
> comes with 9000 bytes as the default MTU?  At least I think that is 
> what I am seeing now that I've started looking more closely.
>
> rick jones


That's the same for the in-kernel-tree code (9K MTU by default). 
Assuming this is not wanted, I will submit a patch for that.


Loic
