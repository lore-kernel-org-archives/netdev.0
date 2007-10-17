From: Jeff Garzik <jgarzik@pobox.com>
Subject: [ofa-general] Re: [PATCH linux-2.6] bonding: two small fixes for
	IPoIB support
Date: Tue, 16 Oct 2007 21:15:58 -0400
Message-ID: <4715624E.8010909@pobox.com>
References: <47138EB7.40703@gmail.com> <4713B006.9090908@pobox.com>
	<27349.1192480486@death> <4713D28F.3010904@pobox.com>
	<31162.1192485233@death> <4713E20F.9080305@pobox.com>
	<9245.1192491867@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <9245.1192491867@death>
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

Jay Vosburgh wrote:
> 	Two small fixes to IPoIB support for bonding:
> 
> 	1- copy header_ops from slave to bonding for IPoIB slaves
> 	2- move release and destroy logic to UNREGISTER from GOING_DOWN
> 	   notifier to avoid double release
> 
> 	Set bonding to version 3.2.1.
> 
> Signed-off-by: Moni Shoua <monis at voltaire.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 

applied
