From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv4 net-next 2/2] bridge: Add a flag to control
 unicast packet flood.
Date: Tue, 30 Apr 2013 12:41:46 -0700
Message-ID: <20130430124146.2091007d@nehalam.linuxnetplumber.net>
References: <1367345928-31135-1-git-send-email-vyasevic@redhat.com>
	<1367345928-31135-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1367345928-31135-3-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Apr 2013 14:18:47 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> +	IFLA_BRPORT_UNICAST_FLOOD,	/* control flood of unicast traffic */

Minor nit, comment could be just
  /* flood unicast traffic */
and the comments for other flags line up, so why not make these line up?
