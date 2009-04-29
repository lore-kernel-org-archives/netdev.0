From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: removing unnecesary
	assignments
Date: Wed, 29 Apr 2009 15:27:06 -0700
Message-ID: <9929d2390904291527i33443866v45a181c6612de5a8@mail.gmail.com>
References: <49F88B2F.4000802@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <49F88B2F.4000802@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Apr 29, 2009 at 10:15 AM, Breno Leitao
<leitao@linux.vnet.ibm.com> wrote:
> This patch removes some assignment that are not necessary. Since the ret
> variable is declared as false during its initialization, it makes no sense to
> reassign false to it again.
>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
>
> ---

Thanks Breno, I have added the patch to my queue of ixgbe patches.  I
will push it with the other ixgbe patches I have, thanks again.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
Register Now & Save for Velocity, the Web Performance & Operations 
Conference from O'Reilly Media. Velocity features a full day of 
expert-led, hands-on workshops and two days of sessions from industry 
leaders in dedicated Performance & Operations tracks. Use code vel09scf 
and Save an extra 15% before 5/3. http://p.sf.net/sfu/velocityconf
