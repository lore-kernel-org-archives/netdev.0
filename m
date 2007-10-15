From: Jeff Garzik <jgarzik@pobox.com>
Subject: [ofa-general] Re: [PATCH V7 0/8] net/bonding: ADD IPoIB support for
 the bonding driver
Date: Mon, 15 Oct 2007 14:23:02 -0400
Message-ID: <4713B006.9090908@pobox.com>
References: <47138EB7.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, fubar@us.ibm.com,
	general@lists.openfabrics.org
To: Moni Shoua <monisonlists@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <47138EB7.40703@gmail.com>
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

Moni Shoua wrote:
> This is the 7th version of this patch series. See link to V6 below.
> 
> Changes from the previous version
> ---------------------------------
> 
> * Some patches required modifications to remove offsets so they can be applied with git-apply
> * Patch #3 was first modified by Jay and later by me to make it work with header_ops
> * patch #8 was changed to fix the problem that caused 'ifconfig down' to stuck (dev_close was called twice)

I just applied the latest version Jay sent, are there any remaining changes?
