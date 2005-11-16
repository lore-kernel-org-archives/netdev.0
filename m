From: Pekka Savola <pekkas@netcore.fi>
Subject: fedora-netdev.1 IPv6 freeze [Re: [ANNOUNCE] fedora-netdev kernel
 repository]
Date: Wed, 16 Nov 2005 12:46:53 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0511161242260.26498@netcore.fi>
References: <20051114205110.GK25755@redhat.com>
Reply-To: Development discussions related to Fedora Core <fedora-devel-list@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <fedora-devel-list-bounces@redhat.com>
To: linville@redhat.com, linville@tuxdriver.com,
	Development discussions related to Fedora Core <fedora-devel-list@redhat.com>
In-Reply-To: <20051114205110.GK25755@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-devel-list>,
	<mailto:fedora-devel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-devel-list>
List-Post: <mailto:fedora-devel-list@redhat.com>
List-Help: <mailto:fedora-devel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-devel-list>,
	<mailto:fedora-devel-list-request@redhat.com?subject=subscribe>
Sender: fedora-devel-list-bounces@redhat.com
Errors-To: fedora-devel-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Nov 2005, John W. Linville wrote:
> 	http://people.redhat.com/linville/kernels/fedora-netdev/

I guess the test can be termed a 'success' because after updating from 
2.6.14-1.1637_FC4 to 2.6.14-1.1637_FC4.netdev.1, I get 100% 
reproducible kernel hang (everything just freezes as it is, no message 
to /var/log/messages or anywhere) after I run '/sbin/ip -6 r l' or try 
to use IPv6 in basically any other way on my ThinkPad laptop with 
external orinoco_cs WLAN card.

Any thoughts for the next steps?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

-- 
fedora-devel-list mailing list
fedora-devel-list@redhat.com
https://www.redhat.com/mailman/listinfo/fedora-devel-list
