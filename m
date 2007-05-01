From: Loic Prylli <loic@myri.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Tue, 01 May 2007 12:26:48 -0400
Message-ID: <46376A48.3050102@myri.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>	<20070425124652.GG1624@mellanox.co.il>	<6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>	<20070426161409.GF15540@mellanox.co.il>	<6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>	<20070426180618.GJ15540@mellanox.co.il>	<6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>	<46325DF3.2050203@hp.com>	<6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>	<46327A07.1000404@hp.com>	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>	<4632894D.40705@hp.com>	<20070428025117.a3b1200a.billfink@mindspring.com>	<46362244.9030406@hp.com>
	<20070501015731.3568d28b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bryan Lawver <lawver1@llnl.gov>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070501015731.3568d28b.billfink@mindspring.com>
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

On 5/1/2007 1:57 AM, Bill Fink wrote:
> On Mon, 30 Apr 2007, Rick Jones wrote:
>
>   
>> Ethtool -i on the interface reports 1.2.0 as the driver version.
>>     
>
> Perhaps it would be useful to have different version strings for
> the in-kernel Linux version and the Myricom externally provided
> version.  Just a thought.
>   


Indeed, and it is the case as of March-21 git (or any myri10ge version 
 >= 1.3.0). The in-kernel version will show something like:
1.3.0-1.226, the external version will only show1.3.0.


Loic
