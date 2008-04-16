From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2.6.26 0/2] Dynamic TBIPA for gianfar
Date: Tue, 15 Apr 2008 21:06:33 -0500
Message-ID: <6C6E8854-3F7A-4661-A5F3-B7CA8676A11A@kernel.crashing.org>
References: <1208276601-16964-1-git-send-email-paul.gortmaker@windriver.com>
	<18437.18289.944128.351533@cargo.ozlabs.ibm.com>
	<7d1d9c250804151857x65cf14cfxe6dc5696505631c7@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	"linuxppc-dev@ozlabs.org list" <linuxppc-dev@ozlabs.org>
To: Paul Gortmaker <paul.gortmaker@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <7d1d9c250804151857x65cf14cfxe6dc5696505631c7@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Apr 15, 2008, at 8:57 PM, Paul Gortmaker wrote:
> On Tue, Apr 15, 2008 at 8:25 PM, Paul Mackerras <paulus@samba.org>  
> wrote:
>> Paul Gortmaker writes:
>>
>>> This is the resend of the two patches as per Andy's request for  
>>> v2.6.26
>>> that allow boards with a PHY at the end of the bus to function, by  
>>> having
>>> the TBIPA set dynamically.  The 1st patch factors out some of the  
>>> PHY
>>> probe code so it can be recycled by the TBIPA probe, and the  
>>> second patch
>>> implements the dynamic probe itself.
>>
>> I notice that these two patches only touch drivers/net and
>> include/linux.  If you want these to go upstream into Linus' tree,  
>> you
>> will need to send them to Jeff Garzik and the netdev list.  Posting
>> them to the linuxppc-dev list is fine for getting them reviewed but
>> isn't a path to upstream.
>
> Yep, they have already been sent to Jeff/netdev earlier today as well.
> I'd inadvertently left them off the CC but Andy reminded me already.
>
> Thanks,
> Paul.

these should get an Ack by Andy before going in to any tree.

- k
