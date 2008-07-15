From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: REVISED AGENDA -- Re: Linux Wireless Mini-Summit -- Ottawa -- July
	22, 2008
Date: Tue, 15 Jul 2008 14:26:54 -0400
Message-ID: <20080715182654.GA5969@tuxdriver.com>
References: <20080709190915.GA8238@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080709190915.GA8238-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I revised the agenda based on the feedback from last week.
Most changes are fairly minor, although I moved the vendor/distro
round table after lunch to give us a chance to cover some in-progress
work beforehand.

As I mentioned elsewhere in the thread, I don't think we have enough
time for work sessions on Tuesday.  As others have pointed-out, there
is plenty of time for extended discussions during the days at OLS.
So I think we should keep Tuesday for more high-level design and
development process discussions.

Feel free to volunteer to cover any of the listed topics.  Further
suggestions to alter or augment the agenda are, of course, still
welcome as well.

Thanks!

John

---

3rd Linux Wireless Summit
Ottawa, Canada
22 July 2008

Proposed Agenda

0830	Meet & Greet

	Introductions and opening remarks

0900	Status Reports

	Overview of where things stand today

	- 802.11n

	- QoS/Multiqueue

	- spectrum management

	- Mesh mode (802.11s)

	- RF kill

1015	Break

1030	Current Work

	Short presentations/discussions about work in progress

	- access point mode

	- cfg80211/nl80211
		- time to push to replace WEXT?
		- tool enhancements and/or userland support?

	- regulatory enforcement (802.11d, CRDA)

	- encrypted management frames (802.11w)

	- virtual hardware (mac80211_hwsim)

	- WiMAX

1200	Lunch/Break (provided by HP)

1300	Vendor/Distro Round Table

	Representatives from hardware vendors and Linux distributions
	discuss issues around cooperation between themselves and the
	development community, what we are doing well, and what problems we
	are causing for each other.

1445	Break

1500	Future work

	Short presentations/discussions about work that has previously
	been suggested or requested

	- power management 
		- suspend/resume
		- power savings

	- lib80211 (code sharing w/ full MAC drivers)

	- rate scaling algorithms
		- minstrel
		- others?

	- userland MLME

	- userland driver implementation

	- organized testing?

1645	Break

1700	Maintainence Issues

	Round table discussion of issues related to maintenance of
	the wireless trees

	- trivial/cleanup patches
		- testing or other requirements?
		- should they have lower priority?
		- should they require ACKs from primary author?

	- submissions to -stable
		- who should drive it?
		- what policies?

	- rate scaling algs
		- driver-specific ok?  what limitations?
		- build policies (part of mac80211.ko?)

	- questions/suggestions/complaints

1800	Dinner/Break (sorry, no funding)

2000	BoF/Break-out Sessions

	Impromptu and/or unscheduled discussions as desired by group
	participants

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
