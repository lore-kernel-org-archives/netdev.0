From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 3.0-rc6-git6: Reported regressions 2.6.38 -> 2.6.39
Date: Sun, 10 Jul 2011 12:54:51 +0200 (CEST)
Message-ID: <AtAvQwe5sAK.A.loH.OlYGOB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some post-2.6.38 regressions introduced=
 before
2.6.39, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.38 regressions, please let=
 us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-07-10       99       26          24
  2011-06-27       94       25          23
  2011-06-12       81       21          18
  2011-05-15       50       12          11
  2011-04-30       38       17          16
  2011-04-17       17       11          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38842
Subject		: panic in elv_completed_request on safe remove usb hard drive
Submitter	: leniviy <basinilya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-06 09:20 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38742
Subject		: After hard power-off, btrfs cannot be recovered except booti=
ng 2.6.38 or below kernel
Submitter	: Ryan Underwood <nemesis-RBwgCYbvQ+vk1uMJSBkQmQ@public.gmane.org>
Date		: 2011-07-03 18:57 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38572
Subject		: New NFS: directory XXX contains a readdir loop seems to be t=
riggered by well-behaving server
Submitter	: Petr Vandrovec <petr-vPk2MGR0e28uaRcfnNAh7A@public.gmane.org>
Date		: 2011-06-30 19:38 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38132
Subject		: [Warning] 2.6.39.x latencytop
Submitter	: Andrew Watts <akwatts-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-14 17:07 (27 days old)
Message-ID	: <80098.5633.qm-tGSp4LqzbTn6X00i2u5GFvu2YVrzzGjVVpNB7YpNyf8@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130807128506490&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38102
Subject		: BUG kmalloc-2048: Poison overwritten
Submitter	: Alexey Zaytsev <alexey.zaytsev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-23 17:33 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37772
Subject		: Sometimes, sound disappears and doesn't want to idle.
Submitter	:  <merkil-kt3qwsSULN8dnm+yROfE0A@public.gmane.org>
Date		: 2011-06-17 22:06 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37752
Subject		: Kernel Panic in drm_vblank_put+0x13/0x50 on P4 HT machine wi=
th 82915G/GV/910GL Integrated Graphics Controller
Submitter	: Martin Rogge <marogge-53koH/AXb86i2/dY4+mD5w@public.gmane.org>
Date		: 2011-06-17 13:02 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37712
Subject		: reboot  / "shutdown -r now" hangs ;  works fine on 2.6.38.7-=
1
Submitter	: Dave Hooper <dave-kId6I2PxnVtBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-06-16 20:50 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37692
Subject		: Linux 2.6.39.x fails to boot - unable to mount root fs
Submitter	: Dan Dart <dandart-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2011-06-16 18:55 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37622
Subject		: Poor wireless performance with Intel 4965AGN with iwl-legacy=
/iwl4965
Submitter	:  <MDstr_1-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-06-16 11:22 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37472
Subject		: Lenovo U160 (i915 black screen)
Submitter	: Robse <rob-se-Dz115AEZgoU@public.gmane.org>
Date		: 2011-06-14 15:17 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37322
Subject		: high load, unresponsive system spinning in rcu_kthread
Submitter	: Ferenc W=C3=A1gner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2011-06-12 14:53 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37312
Subject		: Intel 5100 wifi stopped working with 2.6.39.1
Submitter	: Thibault Dory <dory.thibault-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-12 12:43 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37292
Subject		: kernel BUG at fs/ecryptfs/read_write.c:47!
Submitter	:  <rems14-fqJXh2VwIQ9ByuSxxbvQtw@public.gmane.org>
Date		: 2011-06-12 10:25 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37042
Subject		: linux 3.0.0-rc2 libata-eh.c:4018 ata_scsi_port_error_handler=
+0x80/0x53d on s2disk
Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-09 08:22 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D36952
Subject		: [2.6.39] CIFS write failures where 2.6.38 works
Submitter	: Helge Hafting <helge.hafting-CND4fxrytsY@public.gmane.org>
Date		: 2011-06-01 10:11 (40 days old)
Message-ID	: <4DE6103E.6010100-CND4fxrytsY@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130692387613423&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D36392
Subject		: 2.6.39, 3.0-rc2 Intel DRI Regression: Black Screen after try=
ing to play video
Submitter	: Dennis Jansen <dennis.jansen-S0/GAf8tV78@public.gmane.org>
Date		: 2011-06-01 04:41 (40 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D36332
Subject		: Intel gpu turns external monitor off when X starts
Submitter	: rocko <rockorequin-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-05-31 02:53 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D36182
Subject		: Erroneous package power limit notification since kernel 2.6.=
39
Submitter	: Olaf Freyer <aaron667-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2011-05-22 13:01 (50 days old)
Message-ID	: <4DD9092A.4080507-hi6Y0CQ0nG0@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130606930631131&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D35922
Subject		: SND_USB_AUDIO recording device not initializing correctly
Submitter	:  <bjoern.online-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-05-26 10:30 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D35662
Subject		: softlockup with kernel 2.6.39
Submitter	: Hussam Al-Tayeb <ht990332-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-05-23 08:13 (49 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D35242
Subject		: NULL pointer dereference in intel_sdvo_write_cmd (was Black =
screen after boot)
Submitter	: Ko Mi <chaostya.test-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-05-17 10:27 (55 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D35142
Subject		: 2.6.39-rc7-git1 boot error message (no crash)
Submitter	: werner <w.landgraf-ow1r9FSYgO0@public.gmane.org>
Date		: 2011-05-11 4:58 (61 days old)
Message-ID	: <web-520830057-zcyLqNHFQq3Ee+7He9zlJw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130512952706444&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D34942
Subject		: [Bug] Kdump does not work when panic triggered due to MCE
Submitter	: K.Prasad <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2011-05-06 16:54 (66 days old)
Message-ID	: <20110506165412.GB2719-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130470087226270&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D35642
Subject		: On resume, I sometimes get a kernel oops with led_trigger_un=
register_simple
Submitter	: Sven-Hendrik Haase <sh-5wni8d9J0yJl57MIdRCFDg@public.gmane.org>
Date		: 2011-05-23 00:15 (49 days old)
Patch		: https://patchwork.kernel.org/patch/927582/
		  https://patchwork.kernel.org/patch/927612/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D33242
Subject		: Lockdep splat in autofs with 2.6.39-rc2
Submitter	: Nick Bowler <nbowler-7BP4RkwGw0uXmMXjJBpWqg@public.gmane.org>
Date		: 2011-04-07 19:44 (95 days old)
Message-ID	: <20110407194403.GA29404-7BP4RkwGw0uXmMXjJBpWqg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130220545614682&w=3D=
2
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D130342115008659&w=3D2


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.38 and 2.6.39, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D32012

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
