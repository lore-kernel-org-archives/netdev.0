From: Tziporet Koren <tziporet@dev.mellanox.co.il>
Subject: Re: [ofa-general][PATCH 2/2] mlx4: ConnectX multi functional device
	support
Date: Thu, 02 Jul 2009 18:23:03 +0300
Message-ID: <4A4CD0D7.6070409@mellanox.co.il>
References: <4A3A34F5.9030800@mellanox.co.il>
	<4A4C816A.2040506@mellanox.co.il> <adabpo317c5.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adabpo317c5.fsf@cisco.com>
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

Roland Dreier wrote:
>  > Is there any update, will they make it to 2.6.31?
>
> Not sure... need to evaluate the risk of regression
>   
The risk is very low, however without it our new device coming in July 
will not work on the new kernel :-(
And if not on 2.6.31 can you at list queue it on your future work tree?

Tziporet
