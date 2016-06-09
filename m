From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time() for
 inode timestamps
Date: Thu, 9 Jun 2016 11:28:36 +0100
Message-ID: <575944D4.4010009@redhat.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>, y2038@lists.linaro.org,
        Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, Joern Engel <joern@logfs.org>,
        Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        David Howells <dhowells@redhat.com>, Firo Yang <firogm@gmail.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>,
        Chao Yu <chao2.yu@samsung.com>, linux-f2fs-devel@lists.sourceforge.net,
        Michal Hocko <mhocko@suse.com>,
        Konstantin Khlebnikov <koct9i@gmail.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "J. Bruce F
To: Deepa Dinamani <deepa.kernel@gmail.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi,

GFS2 bits:
Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
