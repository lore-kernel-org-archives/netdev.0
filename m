From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] ***SPAM*** Re: [PATCH 02/21] RDS: Main header file
Date: Tue, 27 Jan 2009 13:24:31 -0600
Message-ID: <497F5F6F.4050307@opengridcomputing.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>	<1233022678-9259-3-git-send-email-andy.grover@oracle.com>	<20090127130543.GD2646@ioremap.net>
	<c0a09e5c0901271123k54010bew9efb6845c1d26bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <c0a09e5c0901271123k54010bew9efb6845c1d26bb@mail.gmail.com>
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

Andrew Grover wrote:
> On Tue, Jan 27, 2009 at 5:05 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
>   
>>> +#define RDS_PORT     18634
>>> +
>>>       
>> What will happen if some application already uses that port?
>>     
>
> RDS errors out.
>
> Yeah we're going to want to get an assigned port at some point, I guess.
>
>   

You should start that process now.  It took a while to get nfsrdma's 
port number through...
